# -*- coding: utf-8 -*-
# Generated by Django 1.9.5 on 2016-07-06 00:02
from __future__ import unicode_literals

from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    initial = True

    dependencies = [
    ]

    operations = [
        migrations.CreateModel(
            name='Choice',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('choice_text', models.CharField(max_length=200)),
                ('votes', models.IntegerField(default=0)),
            ],
        ),
        migrations.CreateModel(
            name='Question',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('rail_id', models.IntegerField(default=0)),
                ('question_text', models.CharField(max_length=500)),
                ('additional_prompt', models.CharField(max_length=500)),
                ('pub_date', models.DateTimeField(verbose_name=b'date published')),
                ('active', models.BooleanField(default=False)),
                ('selected_story_id', models.CharField(max_length=50)),
                ('related_img_filename', models.CharField(max_length=100)),
                ('case_number', models.CharField(blank=True, max_length=25)),
            ],
            options={
                'verbose_name': 'Big Question',
                'verbose_name_plural': 'Big Questions',
            },
        ),
        migrations.AddField(
            model_name='choice',
            name='question',
            field=models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='digitalrail.Question'),
        ),
    ]
