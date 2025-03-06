CREATE TABLE "ai_generated_images" (
	"id" serial PRIMARY KEY NOT NULL,
	"originalImageUrl" varchar NOT NULL,
	"aiGeneratedImageUrl" varchar NOT NULL,
	"roomType" varchar NOT NULL,
	"style" varchar NOT NULL,
	"customization" varchar,
	"userEmail" varchar NOT NULL,
	"created_at" timestamp DEFAULT now() NOT NULL,
	"updated_at" timestamp DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "auth_tokens" (
	"id" serial PRIMARY KEY NOT NULL,
	"user_id" integer NOT NULL,
	"token" varchar(255) NOT NULL,
	"expires_at" timestamp NOT NULL,
	"is_used" boolean DEFAULT false,
	"created_at" timestamp DEFAULT now() NOT NULL,
	CONSTRAINT "auth_tokens_token_unique" UNIQUE("token")
);
--> statement-breakpoint
CREATE TABLE "device_logins" (
	"id" serial PRIMARY KEY NOT NULL,
	"user_id" integer NOT NULL,
	"device_name" varchar(255) NOT NULL,
	"device_location" text,
	"token_id" integer NOT NULL,
	"last_login_at" timestamp DEFAULT now() NOT NULL,
	"created_at" timestamp DEFAULT now() NOT NULL,
	"is_active" boolean DEFAULT true
);
--> statement-breakpoint
CREATE TABLE "users" (
	"id" serial PRIMARY KEY NOT NULL,
	"name" varchar(255) NOT NULL,
	"email" varchar(255) NOT NULL,
	"image" varchar NOT NULL,
	"created_at" timestamp DEFAULT now() NOT NULL,
	"updated_at" timestamp DEFAULT now() NOT NULL,
	"credits" integer DEFAULT 3,
	CONSTRAINT "users_email_unique" UNIQUE("email")
);
