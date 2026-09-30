cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2296"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2296/agentshield_0.2.2296_darwin_amd64.tar.gz"
      sha256 "fb6a05f31cad0cc6eddaf58753e5fb82f285129779a02b073815fbf38d531625"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2296/agentshield_0.2.2296_darwin_arm64.tar.gz"
      sha256 "d14c0c14d127656e4a194910b4c75788d999330d09b998ba6fdb4d5595167547"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2296/agentshield_0.2.2296_linux_amd64.tar.gz"
      sha256 "57fc4e01e7dc35ab011ae5ebcac55d056d5c0428ce5ee6ca404a703ca5da66ef"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2296/agentshield_0.2.2296_linux_arm64.tar.gz"
      sha256 "6568888d622f1b81249f7e9ca6c184de0d01dbc81c0794ec6530d01df7d71f0c"
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
