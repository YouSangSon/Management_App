-- Create users table for custom authentication
CREATE TABLE IF NOT EXISTS public.users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email VARCHAR(255) NOT NULL UNIQUE,
  username VARCHAR(50) NOT NULL UNIQUE,
  full_name VARCHAR(100) NOT NULL,
  password_hash TEXT NOT NULL,
  salt TEXT NOT NULL,
  is_verified BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create index on email and username for faster queries
CREATE INDEX IF NOT EXISTS users_email_idx ON public.users (email);
CREATE INDEX IF NOT EXISTS users_username_idx ON public.users (username);

-- Set RLS policies to secure the table
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- Create policy to allow only authorized operations
CREATE POLICY "Users can only read their own data"
  ON public.users
  FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Only authenticated users can update their own data"
  ON public.users
  FOR UPDATE
  USING (auth.uid() = id);

-- Create policy to allow insert for registration
CREATE POLICY "Anyone can register"
  ON public.users
  FOR INSERT
  WITH CHECK (true);

-- Grant SELECT and UPDATE permissions to authenticated users
GRANT SELECT, UPDATE ON public.users TO authenticated;

-- Grant INSERT permission to anonymous users (for registration)
GRANT INSERT ON public.users TO anon;

-- Ensure service role has all permissions
GRANT ALL ON public.users TO service_role; 