# -*- coding: utf-8 -*-
# Generated by Django 1.9.5 on 2016-11-14 02:03
from __future__ import unicode_literals

from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('digitalrail', '0007_artifact'),
    ]

    operations = [
        migrations.RenameField(
            model_name='artifact',
            old_name='case_number',
            new_name='label',
        ),
    ]
