"""Initial migration

Revision ID: 54ade0a05ba6
Revises: 
Create Date: 2025-02-28 18:19:23.801848
"""

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects.postgresql import INTEGER, VARCHAR

# revision identifiers, used by Alembic.
revision: str = '54ade0a05ba6'
down_revision: Union[str, None] = None
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # ### Create tables ###
    
    # Create 'users' table
    op.create_table(
        'users',
        sa.Column('id', sa.Integer, primary_key=True),
        sa.Column('username', sa.String(), index=True),
        sa.Column('email', sa.String(), unique=True, index=True),
        sa.Column('password', sa.String(), index=True),
        sa.Column('xp', sa.Integer, nullable=True, default=0),
        sa.Column('profile_picture', sa.String(), nullable=True)
    )

    # Create 'playlists' table
    op.create_table(
        'playlists',
        sa.Column('id', sa.Integer, primary_key=True),
        sa.Column('name', sa.String()),
        sa.Column('user_id', sa.Integer, sa.ForeignKey('users.id'))
    )

    # Create 'musics' table
    op.create_table(
        'musics',
        sa.Column('id', sa.Integer, primary_key=True),
        sa.Column('name', sa.String()),
        sa.Column('artist', sa.String()),
        sa.Column('playlist_id', sa.Integer, sa.ForeignKey('playlists.id')),
        sa.Column('genre', sa.String())
    )

    # Create 'favorites' table (many-to-many relationship between users and musics)
    op.create_table(
        'favorites',
        sa.Column('user_id', sa.Integer, sa.ForeignKey('users.id'), primary_key=True),
        sa.Column('music_id', sa.Integer, sa.ForeignKey('musics.id'), primary_key=True)
    )

    # ### Create relationships ###
    op.create_foreign_key('fk_playlist_user', 'playlists', 'users', ['user_id'], ['id'])
    op.create_foreign_key('fk_music_playlist', 'musics', 'playlists', ['playlist_id'], ['id'])


def downgrade() -> None:
    # ### Drop tables ###
    op.drop_table('favorites')
    op.drop_table('musics')
    op.drop_table('playlists')
    op.drop_table('users')
