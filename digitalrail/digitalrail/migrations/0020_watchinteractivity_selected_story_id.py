# -*- coding: utf-8 -*-
# Generated by Django 1.9.5 on 2017-04-19 05:44
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('digitalrail', '0019_watchinteractivity'),
    ]

    operations = [
        migrations.AddField(
            model_name='watchinteractivity',
            name='selected_story_id',
            field=models.IntegerField(blank=True, default=0),
        ),
    ]
