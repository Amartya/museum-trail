# -*- coding: utf-8 -*-
# Generated by Django 1.9.5 on 2016-07-06 00:03
from __future__ import unicode_literals

from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        ('digitalrail', '0001_initial'),
    ]

    operations = [
        migrations.CreateModel(
            name='iModelQuestion',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('imodel_question_text', models.CharField(blank=True, max_length=500)),
                ('imodel_additional_prompt', models.CharField(max_length=500)),
                ('pub_date', models.DateTimeField(verbose_name=b'date published')),
                ('related_img_filename', models.CharField(max_length=100)),
                ('case_number', models.CharField(blank=True, max_length=25)),
            ],
            options={
                'verbose_name': 'iModel Question',
                'verbose_name_plural': 'iModel Questions',
            },
        ),
        migrations.CreateModel(
            name='iModelThematicQuestion',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('rail_id', models.IntegerField(default=0)),
                ('thematic_question', models.CharField(blank=True, max_length=500)),
                ('pub_date', models.DateTimeField(verbose_name=b'date published')),
                ('active', models.BooleanField(default=False)),
            ],
            options={
                'verbose_name': 'iModel Thematic Question',
                'verbose_name_plural': 'iModel Thematic Questions',
            },
        ),
        migrations.AddField(
            model_name='imodelquestion',
            name='thematic_question',
            field=models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='digitalrail.iModelThematicQuestion'),
        ),
    ]
