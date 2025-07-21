from django.contrib import admin

from .models import (
    Player,
    PokerTable,
    HandHistory,
    HandHistoryEvent,
    HandHistoryAction,
    ChatHistory,
    ChatLine,
    PokerTableStats,
    Freezeout,
    PokerTournament,
    TournamentResult,
)


@admin.register(Player)
class PlayerAdmin(admin.ModelAdmin):
    list_display = ('short_id', 'username', 'table', 'seated', 'position', 'stack')

@admin.register(PokerTable)
class PokerTableAdmin(admin.ModelAdmin):
    list_display = ('short_id', 'name', 'table_type', 'tournament', 'num_seats', 'sb', 'bb', 'min_buyin', 'max_buyin', 'hand_number')
    search_fields = ('id', 'name', 'table_type', 'tournament')

@admin.register(HandHistory)
class HandHistoryAdmin(admin.ModelAdmin):
    list_display = ('id', 'table', 'timestamp', 'hand_number')

@admin.register(ChatHistory)
class ChatHistoryAdmin(admin.ModelAdmin):
    list_display = ('short_id', 'users')

    def users(self, history):
        return ', '.join({
            str(s)
            for s in history.chatline_set.all()
                            .values_list('user__username', flat=True)    
        })



admin.site.register(HandHistoryEvent)
admin.site.register(HandHistoryAction)

admin.site.register(ChatLine)
admin.site.register(PokerTableStats)

admin.site.register(Freezeout)
admin.site.register(PokerTournament)
admin.site.register(TournamentResult)
