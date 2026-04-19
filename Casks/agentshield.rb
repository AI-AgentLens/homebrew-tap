cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.658"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.658/agentshield_0.2.658_darwin_amd64.tar.gz"
      sha256 "8e40e1c258c453540e6cdb1472afc2c284443ca4e9fa20d760e1ed58647860b8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.658/agentshield_0.2.658_darwin_arm64.tar.gz"
      sha256 "7e0091a0a863266f42bcbe49a9c03b0d67f77b983a87e7af6d4e33713e804b58"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.658/agentshield_0.2.658_linux_amd64.tar.gz"
      sha256 "898f366e0a050332f3e82272ac2093aaa47a2053671b95e54772d679eaa235b2"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.658/agentshield_0.2.658_linux_arm64.tar.gz"
      sha256 "a71baf758cbd7c8fda78d1ea3a0b3062867ee30fa7a87cca2230867837bb76ce"
    end
  end

  # Stop the heartbeat daemon before upgrading so the old binary doesn't keep
  # running as a zombie after brew replaces it.
  preflight do
    if OS.mac?
      plist = File.expand_path("~/Library/LaunchAgents/com.aiagentlens.agentshield.plist")
      if File.exist?(plist)
        system_command "/bin/launchctl", args: ["bootout", "gui/#{Process.uid}/com.aiagentlens.agentshield"], print_stderr: false
        File.delete(plist) if File.exist?(plist)
      end
    end
  end

  postflight do
    if OS.mac?
      system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "#{staged_path}/agentshield"]
      system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "#{staged_path}/agentcompliance"]
    end
  end

  uninstall launchctl: "com.aiagentlens.agentshield",
            delete:    "~/Library/LaunchAgents/com.aiagentlens.agentshield.plist"

  caveats <<~EOS
    Two tools installed:
      agentshield      — Runtime security gateway for AI agents
      agentcompliance  — Local compliance scanner (semgrep-based)

    Quick start:
      agentshield setup
      agentshield login
  EOS
end
