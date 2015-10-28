<div class="copyright" >
	&copy; &nbsp;
	<span class="author" itemprop="copyrightHolder">{{ config.last_update_date }}</span>
	{% set current = date(Date.now(), "YYYY-MM-DD HH:mm") %}
	{% if theme.since and theme.since != current %} {{ theme.since }} - {% endif %}
	<span itemprop="copyrightYear">{{ current }}</span>
	<span class="with-love">
    <i class="icon-heart"></i>
	</span>
	<span class="author" itemprop="copyrightHolder">{{ config.author }}</span>
</div>


{% block footer %}{% endblock %}
