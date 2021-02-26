-- CreateEnum
CREATE TYPE "Onboards" AS ENUM ('TEAM', 'GOAL', 'FUNNEL');

-- CreateEnum
CREATE TYPE "UserType" AS ENUM ('PUBLIC', 'BETA');

-- CreateTable
CREATE TABLE "users" (
    "id" TEXT NOT NULL,
    "name" TEXT,
    "email" TEXT,
    "email_verified" TIMESTAMP(3),
    "image" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "completed_onboards" "Onboards"[],
    "type" "UserType" NOT NULL DEFAULT E'PUBLIC',

    PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "users.email_unique" ON "users"("email");
