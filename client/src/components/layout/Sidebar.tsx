import React from 'react';
import { Bookmark, Compass, Home, Library, Music, Sliders } from 'lucide-react';
import { useTheme } from '../../context/ThemeContext';
import { LISTENING_PROFILES } from '../../theme/tokens';
import type { ListeningProfile } from '../../theme/tokens';

export type PageView = 'home' | 'search' | 'library';

interface SidebarProps {
  currentPage: PageView;
  onNavigate: (page: PageView) => void;
  onOpenSettings: () => void;
}

export const Sidebar: React.FC<SidebarProps> = ({
  currentPage,
  onNavigate,
  onOpenSettings,
}) => {
  const { config, applyPreset } = useTheme();

  const handleApplyProfile = (profile: ListeningProfile) => {
    applyPreset({ name: profile.name, config: profile.config });
  };

  const navItems = [
    { id: 'home' as PageView, label: 'Home', icon: Home },
    { id: 'search' as PageView, label: 'Search', icon: Compass },
    { id: 'library' as PageView, label: 'Your library', icon: Library },
  ];

  return (
    <aside className="hidden md:flex flex-col w-64 h-[calc(100vh-80px)] p-4 pr-0 select-none">
      {/* Brand Header */}
      <div className="flex items-center space-x-2.5 px-3 py-3 mb-4">
        <div className="w-8 h-8 rounded-[4px] bg-ink text-paper flex items-center justify-center shadow-sm">
          <Music className="w-4 h-4" />
        </div>
        <div>
          <h1 className="font-serif font-bold text-lg text-text tracking-tight leading-none">
            FOLIO
          </h1>
          <span className="text-[10px] text-muted font-mono tracking-wider">
            SANTORI AUDIO
          </span>
        </div>
      </div>

      {/* Folder Tab Navigation */}
      <nav className="space-y-1 mb-6">
        {navItems.map((item) => {
          const Icon = item.icon;
          const active = currentPage === item.id;
          return (
            <button
              key={item.id}
              onClick={() => onNavigate(item.id)}
              className={`w-full flex items-center space-x-3 px-3 py-2.5 rounded-l-[3px] text-sm font-medium transition-all text-left relative ${
                active
                  ? 'bg-paper text-ink font-semibold shadow-paper -mr-px border-r-2 border-ink'
                  : 'text-text hover:bg-black/5 dark:hover:bg-white/5'
              }`}
            >
              <Icon className="w-4 h-4 text-muted group-hover:text-ink" />
              <span>{item.label}</span>
            </button>
          );
        })}
      </nav>

      {/* Listening Profiles Group */}
      <div className="flex-1 overflow-y-auto px-1 space-y-4">
        <div>
          <div className="flex items-center space-x-1.5 px-2 mb-2 text-xs font-semibold text-muted uppercase tracking-wider">
            <Bookmark className="w-3.5 h-3.5" />
            <span>Listening profiles</span>
          </div>

          <div className="space-y-1">
            {LISTENING_PROFILES.map((profile) => {
              const active =
                config.shade === profile.config.shade &&
                config.ink === profile.config.ink;
              return (
                <button
                  key={profile.id}
                  onClick={() => handleApplyProfile(profile)}
                  className={`w-full text-left px-3 py-2 rounded-[3px] text-xs transition-colors flex flex-col ${
                    active
                      ? 'bg-paper text-ink font-semibold shadow-sm border border-rule/50'
                      : 'text-text hover:bg-black/5 dark:hover:bg-white/5'
                  }`}
                  title={profile.description}
                >
                  <span className="truncate">{profile.name}</span>
                  <span className="text-[10px] text-muted truncate mt-0.5">
                    {profile.description}
                  </span>
                </button>
              );
            })}
          </div>
        </div>
      </div>

      {/* Bottom Desk Settings Button */}
      <div className="pt-3 border-t border-rule/50 pr-4">
        <button
          onClick={onOpenSettings}
          className="w-full flex items-center justify-between px-3 py-2.5 rounded-[3px] bg-paper2 hover:bg-paper text-text hover:text-ink text-xs font-medium border border-rule/60 transition-colors shadow-sm"
        >
          <div className="flex items-center space-x-2">
            <Sliders className="w-3.5 h-3.5 text-ink" />
            <span>Desk settings</span>
          </div>
          <span className="text-[10px] text-muted font-mono capitalize">
            {config.shade}
          </span>
        </button>
      </div>
    </aside>
  );
};
