---
layout: page
title: Telegram
---

## Bots

### Example Telegram bot for Python

```py
import os
from datetime import time

from telegram import Update
from telegram.ext import ApplicationBuilder, CommandHandler, ContextTypes, filters, MessageHandler
from dotenv import load_dotenv

from config import ALLOWED_USER_IDS

load_dotenv()


async def hello_command(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    await update.message.reply_text(f'Hello {update.effective_user.first_name}')


async def handle_message(update, context):
    user_id = update.effective_user.id

    if user_id not in ALLOWED_USER_IDS:
        await update.message.reply_text("Sorry, this bot is private.")
        return

    await update.message.reply_text(update.message.text)


def main() -> None:
    app = ApplicationBuilder().token(os.environ.get("TELEGRAM_BOT_TOKEN")).build()

    app.add_handler(CommandHandler("hello", hello_command))
    app.add_handler(MessageHandler(filters.TEXT & ~filters.COMMAND, handle_message))

    print("Starting bot...")
    app.run_polling(
        allowed_updates=Update.ALL_TYPES,
        drop_pending_updates=True  # Ignore old messages after restart
    )


if __name__ == "__main__":
    main()
```
