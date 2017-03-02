# -*- coding: utf-8 -*-
# Generated by Django 1.9.5 on 2017-03-02 03:40
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('digitalrail', '0018_artifactqa_artifact_dynasty_age'),
    ]

    operations = [
        migrations.CreateModel(
            name='WatchInteractivity',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('show_watch_area', models.BooleanField(default=False)),
            ],
            options={
                'verbose_name': 'Watch Property',
                'verbose_name_plural': 'Watch Properties',
            },
        ),
    ]
