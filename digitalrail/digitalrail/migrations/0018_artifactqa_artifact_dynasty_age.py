# -*- coding: utf-8 -*-
# Generated by Django 1.9.5 on 2016-11-16 16:42
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('digitalrail', '0017_remove_artifactqa_artifact_dynasty_age'),
    ]

    operations = [
        migrations.AddField(
            model_name='artifactqa',
            name='artifact_dynasty_age',
            field=models.CharField(blank=True, max_length=50),
        ),
    ]
