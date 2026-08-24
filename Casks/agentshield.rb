cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1945"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1945/agentshield_0.2.1945_darwin_amd64.tar.gz"
      sha256 "88f8993f910012f6255b3dfc39721415e81d471702409514762691ea5b03d5b6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1945/agentshield_0.2.1945_darwin_arm64.tar.gz"
      sha256 "1820403476493d57fd9ba451c6a76a95d6ef2af3082f2e7278908e872c03e80c"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1945/agentshield_0.2.1945_linux_amd64.tar.gz"
      sha256 "1b78ca9423da900f5b1de67902dcbbc6b4d2bf7a4ac43d6194b3c78503300e9b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1945/agentshield_0.2.1945_linux_arm64.tar.gz"
      sha256 "204f51f72acc90d79a3f0a7ea17d3a9792e46251870bda76a5e734b4a9848c1b"
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
