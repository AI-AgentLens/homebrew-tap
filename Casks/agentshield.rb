cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.457"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.457/agentshield_0.2.457_darwin_amd64.tar.gz"
      sha256 "f98fc936a0ae3ff3aa098a1b2d96a549b6b30f48aec10cc1f8e45f497f54c005"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.457/agentshield_0.2.457_darwin_arm64.tar.gz"
      sha256 "06bec416e91eaf8fb4d395a7660d672fe7396d8c5590cc3036c82e9897869c61"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.457/agentshield_0.2.457_linux_amd64.tar.gz"
      sha256 "681382db2859beb2627e4ea407be2a5225898921c950782b221b5b9de106abae"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.457/agentshield_0.2.457_linux_arm64.tar.gz"
      sha256 "55b08b0cd6d7493df3f75b16ad91bac21fc031cc8d15b376bd50ca9157c04c26"
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
