from django.db import models

# --------------------------------------------------------- #
# ---------------Model for the Big Question --------------- #
# --------------------------------------------------------- #
class Question(models.Model):
    def __unicode__(self):
        return 'RailId: ' + str(self.rail_id) + ' Question: ' + self.question_text

    class Meta:
        verbose_name = 'Big Question'
        verbose_name_plural = 'Big Questions'

    rail_id = models.IntegerField(default=0)
    question_text = models.CharField(max_length=500)
    additional_prompt = models.CharField(max_length=500)
    pub_date = models.DateTimeField('date published')
    active = models.BooleanField(default=False)
    selected_story_id = models.CharField(max_length=50)
    related_img_filename = models.CharField(max_length=100)
    case_number = models.CharField(max_length=25, blank=True)

# --------------------------------------------------------- #
# -----------------iModel THEMATIC Question---------------- #
# --------------------------------------------------------- #
class iModelThematicQuestion(models.Model):
    def __unicode__(self):
        return 'RailId: ' + str(self.rail_id) + ' Question: ' + self.thematic_question

    class Meta:
        verbose_name = 'iModel Thematic Question'
        verbose_name_plural = 'iModel Thematic Questions'

    rail_id = models.IntegerField(default=0)
    thematic_question = models.CharField(max_length=500, blank=True)
    pub_date = models.DateTimeField('date published')
    active = models.BooleanField(default=False)

# --------------------------------------------------------- #
# ---------------------iModel Question -------------------- #
# --------------------------------------------------------- #
class iModelQuestion(models.Model):
    def __unicode__(self):
        return 'RailId: ' + str(self.thematic_question.rail_id) + ' - Question: ' + self.imodel_question_text

    class Meta:
        verbose_name = 'iModel Question'
        verbose_name_plural = 'iModel Questions'

    thematic_question = models.ForeignKey(iModelThematicQuestion, on_delete=models.CASCADE)
    imodel_artifact_name = models.CharField(max_length=500, blank=True)
    imodel_question_text = models.CharField(max_length=500, blank=True)
    imodel_additional_prompt = models.CharField(max_length=500)
    pub_date = models.DateTimeField('date published')
    related_img_filename = models.CharField(max_length=100)
    case_number = models.CharField(max_length=25, blank=True)


# --------------------------------------------------------- #
# ------------------------For Polls ----------------------- #
# --------------------------------------------------------- #
class Choice(models.Model):
    question = models.ForeignKey(Question, on_delete=models.CASCADE)
    choice_text = models.CharField(max_length=200)
    votes = models.IntegerField(default=0)