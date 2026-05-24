-- ─────────────────────────────────────────────────────────────────────────────
-- SHAMS PLATFORM - NOTIFICATIONS DATABASE SETUP
-- ─────────────────────────────────────────────────────────────────────────────
--
-- Choose ONE of the following options to run in your Supabase SQL Editor:

-- =============================================================================
-- OPTION 1: ALLOW CLIENT-SIDE INSERTION (Recommended & Easiest)
-- =============================================================================
-- This will update the Row-Level Security (RLS) policies of the "notifications"
-- table to allow logged-in users to write notifications for other users.
-- This works instantly with the Flutter/Dart logic we implemented.

-- Allow authenticated users to insert notifications
DROP POLICY IF EXISTS "Allow authenticated inserts" ON notifications;
CREATE POLICY "Allow authenticated inserts" ON notifications
FOR INSERT TO authenticated WITH CHECK (true);

-- Allow users to view only their own notifications
DROP POLICY IF EXISTS "Allow users to view their own notifications" ON notifications;
CREATE POLICY "Allow users to view their own notifications" ON notifications
FOR SELECT TO authenticated USING (auth.uid() = user_id);

-- Allow users to update their own notifications (e.g. mark as read)
DROP POLICY IF EXISTS "Allow users to update their own notifications" ON notifications;
CREATE POLICY "Allow users to update their own notifications" ON notifications
FOR UPDATE TO authenticated USING (auth.uid() = user_id);

-- Allow users to delete their own notifications
DROP POLICY IF EXISTS "Allow users to delete their own notifications" ON notifications;
CREATE POLICY "Allow users to delete their own notifications" ON notifications
FOR DELETE TO authenticated USING (auth.uid() = user_id);


-- =============================================================================
-- OPTION 2: DATABASE-LEVEL TRIGGER CONVERSION (Advanced & Secure)
-- =============================================================================
-- If you run this option, notifications will be automatically generated at the 
-- database level whenever a message, like, or maintenance request is inserted.
-- Note: If you choose this option, we should remove the client-side insertion 
-- logic in the Flutter code to prevent duplicate notifications.

/*

-- 1. Like Notification Trigger
CREATE OR REPLACE FUNCTION handle_post_like_notification()
RETURNS TRIGGER AS $$
DECLARE
  post_author_id UUID;
  liker_name TEXT;
  post_text TEXT;
BEGIN
  SELECT author_id, text_details INTO post_author_id, post_text
  FROM posts WHERE id = NEW.post_id;
  
  SELECT name INTO liker_name
  FROM profiles WHERE id = NEW.user_id;

  IF post_author_id IS NOT NULL AND post_author_id != NEW.user_id THEN
    INSERT INTO notifications (user_id, title, message, type, target_id)
    VALUES (
      post_author_id,
      'إعجاب جديد',
      liker_name || ' قام بالإعجاب بمنشورك: "' || CASE WHEN length(post_text) > 30 THEN substring(post_text from 1 for 30) || '...' ELSE post_text END || '"',
      'like',
      NEW.post_id
    );
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE TRIGGER trigger_post_like_notification
AFTER INSERT ON post_likes
FOR EACH ROW EXECUTE FUNCTION handle_post_like_notification();


-- 2. Message Notification Trigger
CREATE OR REPLACE FUNCTION handle_message_notification()
RETURNS TRIGGER AS $$
DECLARE
  recipient_user_id UUID;
  sender_name TEXT;
BEGIN
  SELECT user_id INTO recipient_user_id
  FROM chat_participants
  WHERE chat_id = NEW.chat_id AND user_id != NEW.sender_id
  LIMIT 1;

  SELECT name INTO sender_name
  FROM profiles WHERE id = NEW.sender_id;

  IF recipient_user_id IS NOT NULL THEN
    INSERT INTO notifications (user_id, title, message, type, target_id)
    VALUES (
      recipient_user_id,
      'رسالة جديدة',
      'أرسل ' || sender_name || ': ' || NEW.text,
      'message',
      NEW.chat_id
    );
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE TRIGGER trigger_message_notification
AFTER INSERT ON messages
FOR EACH ROW EXECUTE FUNCTION handle_message_notification();


-- 3. Maintenance Request Notification Trigger
CREATE OR REPLACE FUNCTION handle_maintenance_request_notification()
RETURNS TRIGGER AS $$
DECLARE
  workshop_owner_id UUID;
  client_name TEXT;
BEGIN
  SELECT owner_id INTO workshop_owner_id
  FROM workshops WHERE id = NEW.workshop_id;

  SELECT name INTO client_name
  FROM profiles WHERE id = NEW.client_id;

  IF workshop_owner_id IS NOT NULL THEN
    INSERT INTO notifications (user_id, title, message, type, target_id)
    VALUES (
      workshop_owner_id,
      'طلب صيانة جديد',
      'تلقيت طلب صيانة جديد من ' || client_name || ' (' || NEW.service_type || ')',
      'maintenance_status',
      NEW.id
    );
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE TRIGGER trigger_maintenance_request_notification
AFTER INSERT ON maintenance_requests
FOR EACH ROW EXECUTE FUNCTION handle_maintenance_request_notification();


-- 4. Maintenance Request Status Update Notification Trigger
CREATE OR REPLACE FUNCTION handle_maintenance_status_notification()
RETURNS TRIGGER AS $$
DECLARE
  workshop_name TEXT;
  status_str TEXT;
BEGIN
  SELECT name INTO workshop_name
  FROM workshops WHERE id = NEW.workshop_id;

  status_str := CASE NEW.status
    WHEN 'accepted' THEN 'مقبول'
    WHEN 'rejected' THEN 'مرفوض'
    WHEN 'completed' THEN 'مكتمل'
    ELSE 'قيد الانتظار'
  END;

  IF OLD.status IS DISTINCT FROM NEW.status THEN
    INSERT INTO notifications (user_id, title, message, type, target_id)
    VALUES (
      NEW.client_id,
      'تحديث طلب الصيانة',
      'تم تحديث حالة طلب الصيانة (' || NEW.service_type || ') لدى ' || workshop_name || ' إلى: ' || status_str,
      'maintenance_status',
      NEW.id
    );
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE TRIGGER trigger_maintenance_status_notification
AFTER UPDATE OF status ON maintenance_requests
FOR EACH ROW EXECUTE FUNCTION handle_maintenance_status_notification();

*/
