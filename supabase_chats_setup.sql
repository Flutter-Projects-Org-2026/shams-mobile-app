-- ─────────────────────────────────────────────────────────────────────────────
-- SHAMS PLATFORM - CHATS, PARTICIPANTS, AND MESSAGES DATABASE SETUP (RLS)
-- ─────────────────────────────────────────────────────────────────────────────
-- Run this SQL in your Supabase SQL Editor to enable Row-Level Security (RLS)
-- and add secure policies that guarantee chats are only visible to their participants.

-- =============================================================================
-- 1. SECURITY DEFINER HELPER FUNCTION
-- =============================================================================
-- This function runs with SECURITY DEFINER privileges to bypass RLS internally
-- and safely check if a user is a participant of a chat without recursion.
CREATE OR REPLACE FUNCTION public.is_chat_participant(chat_uuid UUID, user_uuid UUID)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 
    FROM public.chat_participants 
    WHERE chat_id = chat_uuid AND user_id = user_uuid
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


-- This function securely creates a new chat and registers participants atomically
-- to avoid row-level security (RLS) select policy violations on creation.
CREATE OR REPLACE FUNCTION public.create_new_chat(other_user_uuid UUID, maintenance_req_uuid UUID DEFAULT NULL)
RETURNS UUID AS $$
DECLARE
  new_chat_id UUID;
  user_uuid UUID;
BEGIN
  user_uuid := auth.uid();
  IF user_uuid IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  -- Insert new chat record
  INSERT INTO public.chats (maintenance_req_id)
  VALUES (maintenance_req_uuid)
  RETURNING id INTO new_chat_id;

  -- Add participants (both creator and other participant)
  INSERT INTO public.chat_participants (chat_id, user_id)
  VALUES 
    (new_chat_id, user_uuid),
    (new_chat_id, other_user_uuid);

  RETURN new_chat_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


-- =============================================================================
-- 2. SECURE "chats" TABLE
-- =============================================================================
-- Enable Row-Level Security
ALTER TABLE chats ENABLE ROW LEVEL SECURITY;

-- Select Policy: Users can only see chats they participate in
DROP POLICY IF EXISTS "Allow users to view their own chats" ON chats;
CREATE POLICY "Allow users to view their own chats" ON chats
FOR SELECT TO authenticated
USING (
  public.is_chat_participant(id, auth.uid())
);

-- Insert Policy: Authenticated users can create new chats
DROP POLICY IF EXISTS "Allow authenticated users to create chats" ON chats;
CREATE POLICY "Allow authenticated users to create chats" ON chats
FOR INSERT TO authenticated
WITH CHECK (true);

-- Update Policy: Only participants can update chat metadata
DROP POLICY IF EXISTS "Allow participants to update chats" ON chats;
CREATE POLICY "Allow participants to update chats" ON chats
FOR UPDATE TO authenticated
USING (
  public.is_chat_participant(id, auth.uid())
)
WITH CHECK (
  public.is_chat_participant(id, auth.uid())
);

-- Delete Policy: Only participants can delete chats
DROP POLICY IF EXISTS "Allow participants to delete chats" ON chats;
CREATE POLICY "Allow participants to delete chats" ON chats
FOR DELETE TO authenticated
USING (
  public.is_chat_participant(id, auth.uid())
);


-- =============================================================================
-- 3. SECURE "chat_participants" TABLE
-- =============================================================================
-- Enable Row-Level Security
ALTER TABLE chat_participants ENABLE ROW LEVEL SECURITY;

-- Select Policy: Users can view other participants in the same chat
DROP POLICY IF EXISTS "Allow users to view participants in their own chats" ON chat_participants;
CREATE POLICY "Allow users to view participants in their own chats" ON chat_participants
FOR SELECT TO authenticated
USING (
  public.is_chat_participant(chat_id, auth.uid())
);

-- Insert Policy: Authenticated users can add participants
DROP POLICY IF EXISTS "Allow users to add participants" ON chat_participants;
CREATE POLICY "Allow users to add participants" ON chat_participants
FOR INSERT TO authenticated
WITH CHECK (true);

-- Delete Policy: Participants can leave or delete participant listings
DROP POLICY IF EXISTS "Allow users to delete chat participants" ON chat_participants;
CREATE POLICY "Allow users to delete chat participants" ON chat_participants
FOR DELETE TO authenticated
USING (
  public.is_chat_participant(chat_id, auth.uid())
);


-- =============================================================================
-- 4. SECURE "messages" TABLE
-- =============================================================================
-- Enable Row-Level Security
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;

-- Select Policy: Only chat participants can read messages
DROP POLICY IF EXISTS "Allow participants to view chat messages" ON messages;
CREATE POLICY "Allow participants to view chat messages" ON messages
FOR SELECT TO authenticated
USING (
  public.is_chat_participant(chat_id, auth.uid())
);

-- Insert Policy: Only participants can send messages inside their chats
DROP POLICY IF EXISTS "Allow participants to send messages" ON messages;
CREATE POLICY "Allow participants to send messages" ON messages
FOR INSERT TO authenticated
WITH CHECK (
  public.is_chat_participant(chat_id, auth.uid()) AND sender_id = auth.uid()
);

-- Update Policy: Participants can update message attributes (e.g., is_read status)
DROP POLICY IF EXISTS "Allow participants to update message status" ON messages;
CREATE POLICY "Allow participants to update message status" ON messages
FOR UPDATE TO authenticated
USING (
  public.is_chat_participant(chat_id, auth.uid())
)
WITH CHECK (
  public.is_chat_participant(chat_id, auth.uid())
);

-- Delete Policy: Participants can delete messages
DROP POLICY IF EXISTS "Allow participants to delete messages" ON messages;
CREATE POLICY "Allow participants to delete messages" ON messages
FOR DELETE TO authenticated
USING (
  public.is_chat_participant(chat_id, auth.uid())
);
