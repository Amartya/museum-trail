# -*- coding: utf-8 -*-
# Generated by Django 1.9.5 on 2016-07-06 00:49
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('digitalrail', '0002_auto_20160706_0003'),
    ]

    operations = [
        migrations.AddField(
            model_name='imodelquestion',
            name='imodel_artifact_name',
            field=models.CharField(blank=True, max_length=500),
        ),
    ]
