from django.contrib.sitemaps import Sitemap
from django.urls import reverse
from .models import Poll

class StaticViewSitemap(Sitemap):
    priority = 0.5
    changefreq = 'daily'

    def items(self):
        return ['voting:index', 'voting:about_condorcet', 'voting:create_poll']

    def location(self, item):
        return reverse(item)

class PollSitemap(Sitemap):
    changefreq = 'hourly'
    priority = 0.8

    def items(self):
        # Only include public, active, non-deleted polls
        return Poll.objects.filter(is_public=True, is_active=True, is_deleted=False)

    def location(self, obj):
        return reverse('voting:vote_poll', args=[obj.id])

    def lastmod(self, obj):
        return obj.updated_at
