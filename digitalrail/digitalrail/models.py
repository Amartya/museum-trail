from django.db import models


class Question(models.Model):
    def __unicode__(self):
        return 'RailId: ' + str(self.rail_id) + ' Question: ' + self.question_text
    rail_id = models.IntegerField(default=0)
    question_text = models.CharField(max_length=500)
    imodel_question_text = models.CharField(max_length=500, blank=True)
    pub_date = models.DateTimeField('date published')
    active = models.BooleanField(default=False)
    imodel = models.BooleanField(default=False)
    additional_prompt = models.CharField(max_length=500)
    selected_story_id = models.CharField(max_length=50)
    related_img_filename = models.CharField(max_length=100)
    case_number = models.CharField(max_length=25, blank=True)

class Choice(models.Model):
    question = models.ForeignKey(Question, on_delete=models.CASCADE)
    choice_text = models.CharField(max_length=200)
    votes = models.IntegerField(default=0)