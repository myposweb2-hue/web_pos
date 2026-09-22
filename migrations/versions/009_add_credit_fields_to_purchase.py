"""Add credit metadata fields to purchases

Revision ID: 009_credit_purchase_meta
Revises: 008_add_sale_status
Create Date: 2026-09-22 00:00:00.000000

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = '009_credit_purchase_meta'
down_revision = '008_add_sale_status'
branch_labels = None
depends_on = None


def upgrade():
    with op.batch_alter_table('purchases') as batch_op:
        batch_op.add_column(sa.Column('credit_due_date', sa.Date(), nullable=True))
        batch_op.add_column(sa.Column('credit_days', sa.Integer(), nullable=True))


def downgrade():
    with op.batch_alter_table('purchases') as batch_op:
        batch_op.drop_column('credit_days')
        batch_op.drop_column('credit_due_date')
