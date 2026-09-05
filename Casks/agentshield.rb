cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2049"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2049/agentshield_0.2.2049_darwin_amd64.tar.gz"
      sha256 "1eeac7021bfad4fe35bb5ec80801ec78697da1bd46ce919e37f8ee8f93577efa"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2049/agentshield_0.2.2049_darwin_arm64.tar.gz"
      sha256 "c3aeda9751ee42bbda05c59db658b4717080814a2430f0b0c21b1b6e986c69b7"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2049/agentshield_0.2.2049_linux_amd64.tar.gz"
      sha256 "8bcd01c13292b1763052e10359494881e46c0c0ec987232e2fa79d2811820242"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2049/agentshield_0.2.2049_linux_arm64.tar.gz"
      sha256 "236715040208dbe5ad0522e2e66a16aba4ab37b8c73e7ffad18f6efabe6a9fc2"
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
