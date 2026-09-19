"""Add status column to sales

Revision ID: 008_add_sale_status
Revises: 007_merge_existing_heads
Create Date: 2026-09-19 00:00:00.000000

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = '008_add_sale_status'
down_revision = '007_merge_existing_heads'
branch_labels = None
depends_on = None


def upgrade():
    # Add status column to sales with default 'Pending' for existing rows
    with op.batch_alter_table('sales') as batch_op:
        batch_op.add_column(sa.Column('status', sa.String(length=20), nullable=False, server_default='Pending'))
    # Remove server_default so future inserts use model default unless explicitly set
    with op.get_bind().connect() as conn:
        try:
            conn.execute(sa.text("ALTER TABLE sales ALTER COLUMN status DROP DEFAULT"))
        except Exception:
            # Some DBs (SQLite) don't support ALTER COLUMN DROP DEFAULT; ignore
            pass


def downgrade():
    with op.batch_alter_table('sales') as batch_op:
        batch_op.drop_column('status')
