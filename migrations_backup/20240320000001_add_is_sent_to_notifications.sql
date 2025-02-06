-- Add is_sent column to notifications table
ALTER TABLE notifications ADD COLUMN IF NOT EXISTS is_sent BOOLEAN DEFAULT FALSE;

-- Update existing records
UPDATE notifications SET is_sent = FALSE WHERE is_sent IS NULL; 