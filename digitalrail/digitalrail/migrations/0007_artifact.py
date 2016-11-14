# -*- coding: utf-8 -*-
# Generated by Django 1.9.5 on 2016-11-14 01:26
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('digitalrail', '0006_imodelquestion_selected_story_id'),
    ]

    operations = [
        migrations.CreateModel(
            name='Artifact',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('rail_id', models.IntegerField(default=0)),
                ('artifact_id', models.IntegerField(default=0)),
                ('artifact_name', models.CharField(blank=True, max_length=500)),
                ('case_number', models.CharField(blank=True, max_length=25)),
                ('related_img_filename', models.CharField(max_length=100)),
                ('has_interactive', models.BooleanField(default=True)),
            ],
            options={
                'verbose_name': 'Artifact',
                'verbose_name_plural': 'Artifacts',
            },
        ),
    ]
