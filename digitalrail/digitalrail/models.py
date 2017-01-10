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
    selected_story_id = models.CharField(max_length=50)
    related_img_filename = models.CharField(max_length=100)
    case_number = models.CharField(max_length=25, blank=True)

# --------------------------------------------------------- #
# --------------------For Rail Settings ------------------- #
# --------------------------------------------------------- #
class RailSettings(models.Model):
    def __unicode__(self):
        return 'RailId: ' + str(self.rail_id) + ' - Timeout: ' + str(self.timeout_seconds)

    class Meta:
        verbose_name = 'Rail Setting'
        verbose_name_plural = 'Rail Settings'

    rail_id = models.IntegerField(default=0)
    timeout_seconds = models.IntegerField(default=180)


# --------------------------------------------------------- #
# ----------------For Interactive Redesign ---------------- #
# --------------------------------------------------------- #
class Artifact(models.Model):
    def __unicode__(self):
        return 'Artifact: ' + self.artifact_name

    class Meta:
        verbose_name = 'Artifact'
        verbose_name_plural = 'Artifacts'

    rail_id = models.IntegerField(default=0)
    artifact_id = models.IntegerField(default=0)
    artifact_name = models.CharField(max_length=500, blank=True)
    artifact_overlay_text = models.CharField(max_length=500, blank=True);
    label = models.CharField(max_length=25, blank=True)
    related_img_filename = models.CharField(max_length=100)
    interactive_type = models.CharField(max_length=20)

class ArtifactQA(models.Model):
    def __unicode__(self):
        return 'Artifact: ' + self.artifact.artifact_name

    class Meta:
        verbose_name = 'Artifact Question Answer'
        verbose_name_plural = 'Artifact Questions Answers'

    artifact = models.ForeignKey(Artifact, on_delete=models.CASCADE)
    artifact_name = models.CharField(max_length=500, blank=True);
    artifact_label = models.CharField(max_length=20, blank=True);
    artifact_dynasty_age = models.CharField(max_length=50, blank=True);
    artifact_questions = models.CharField(max_length=500, blank=True);
    artifact_answers = models.CharField(max_length=2000, blank=True);

class ArtifactDetail(models.Model):
    def __unicode__(self):
        return 'Artifact: ' + self.artifact.artifact_name

    class Meta:
        verbose_name = 'Artifact Detail'
        verbose_name_plural = 'Artifact Detail'

    artifact = models.ForeignKey(Artifact, on_delete=models.CASCADE)
    artifact_heading = models.CharField(max_length=500, blank=True);
    artifact_rights = models.CharField(max_length=500, blank=True);
    artifact_caption = models.CharField(max_length=500, blank=True);

class InteractiveDetail(models.Model):
    def __unicode__(self):
        return 'Artifact: ' + self.artifact.artifact_name

    class Meta:
        verbose_name = 'Interactive Detail'
        verbose_name_plural = 'Interactives Detail'

    artifact = models.ForeignKey(Artifact, on_delete=models.CASCADE)
    interactive_subheading = models.CharField(max_length=500, blank=True);
    interactive_img_url = models.CharField(max_length=500, blank=True);

# --------------------------------------------------------- #
# ------------------------For Polls ----------------------- #
# --------------------------------------------------------- #
class Choice(models.Model):
    question = models.ForeignKey(Question, on_delete=models.CASCADE)
    choice_text = models.CharField(max_length=200)
    votes = models.IntegerField(default=0)