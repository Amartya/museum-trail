# -*- coding: utf-8 -*-
# Generated by Django 1.9.5 on 2016-11-16 16:42
from __future__ import unicode_literals

from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('digitalrail', '0016_artifactqa'),
    ]

    operations = [
        migrations.RemoveField(
            model_name='artifactqa',
            name='artifact_dynasty_age',
        ),
    ]
