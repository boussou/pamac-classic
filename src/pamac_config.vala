/*
 *  pamac-vala
 *
 *  Copyright (C) 2017 Chris Cromer <cromer@cromnix.org>
 *  Copyright (C) 2014-2017 Guillaume Benoit <guillaume@manjaro.org>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a get of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

namespace Pamac {
	public class Config {
		HashTable<string,string> _environment_variables;

		Settings? get_settings_if_installed (string schema_id) {
			SettingsSchemaSource? source = SettingsSchemaSource.get_default ();
			if (source == null) {
				return null;
			}
			SettingsSchema? schema = source.lookup (schema_id, true);
			if (schema == null) {
				return null;
			}
			return new Settings.full (schema, null, null);
		}

		public bool recurse { get; private set; }
		public uint64 refresh_period { get; private set; }
		public bool no_update_hide_icon { get; private set; }
#if DISABLE_AUR
#else
		public bool enable_aur { get; private set; }
		public bool search_aur { get; private set; }
		public string aur_build_dir { get; private set; }
		public bool check_aur_updates { get; private set; }
		public bool aur_keep_pkgs { get; private set; }
		public string aur_move_dir { get; private set; }
#endif
		public uint64 keep_num_pkgs { get; private set; }
		public bool rm_only_uninstalled { get; private set; }
		public string terminal_background { get; private set; }
		public string terminal_foreground { get; private set; }
		public string terminal_font { get; private set; }
		public bool update_files_db { get; private set; }
		public unowned HashTable<string,string> environment_variables {
			get {
				return _environment_variables;
			}
		}

		public Config () {
			//get environment variables
			_environment_variables = new HashTable<string,string> (str_hash, str_equal);
			var utsname = Posix.utsname();
			_environment_variables.insert ("HTTP_USER_AGENT", "pamac (%s %s)".printf (utsname.sysname, utsname.machine));
			unowned string? variable = Environment.get_variable ("http_proxy");
			if (variable != null) {
				_environment_variables.insert ("http_proxy", variable);
			}
			variable = Environment.get_variable ("https_proxy");
			if (variable != null) {
				_environment_variables.insert ("https_proxy", variable);
			}
			variable = Environment.get_variable ("ftp_proxy");
			if (variable != null) {
				_environment_variables.insert ("ftp_proxy", variable);
			}
			variable = Environment.get_variable ("socks_proxy");
			if (variable != null) {
				_environment_variables.insert ("socks_proxy", variable);
			}
			variable = Environment.get_variable ("no_proxy");
			if (variable != null) {
				_environment_variables.insert ("no_proxy", variable);
			}
			// set default options
			recurse = false;
			refresh_period = 6;
			no_update_hide_icon = false;
			keep_num_pkgs = 3;
			rm_only_uninstalled = false;
			terminal_background = "#000000";
			terminal_foreground = "#FFFFFF";
			terminal_font = "Monospace 10";
			update_files_db = false;
#if DISABLE_AUR
#else
			enable_aur = false;
			search_aur = false;
			check_aur_updates = false;
			aur_build_dir = "/var/tmp";
			aur_keep_pkgs = false;
			aur_move_dir = "";
#endif
			reload ();
		}

		public void reload () {
			Settings? settings = get_settings_if_installed ("org.pamac.main");
			if (settings != null) {
				recurse = settings.get_boolean ("remove-unrequired-deps");
				refresh_period = settings.get_uint64 ("refresh-period");
				no_update_hide_icon = settings.get_boolean ("no-update-hide-icon");
				keep_num_pkgs = settings.get_uint64 ("keep-num-packages");
				rm_only_uninstalled = settings.get_boolean ("only-rm-uninstalled");
				terminal_background = settings.get_string ("background-color");
				terminal_foreground = settings.get_string ("foreground-color");
				terminal_font = settings.get_string ("terminal-font");
				update_files_db = settings.get_boolean ("update-files-db");
			}
#if DISABLE_AUR
#else
			settings = get_settings_if_installed ("org.pamac.aur");
			if (settings != null) {
				enable_aur = settings.get_boolean ("enable-aur");
				search_aur = settings.get_boolean ("search-in-aur");
				check_aur_updates = settings.get_boolean ("check-aur-updates");
				aur_build_dir = settings.get_string ("build-directory");
				aur_keep_pkgs = settings.get_boolean("aur-keep-pkgs");
				aur_move_dir = settings.get_string("move-directory");
			}
#endif
		}
	}
}
