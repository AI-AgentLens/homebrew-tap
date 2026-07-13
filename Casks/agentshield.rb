cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1633"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1633/agentshield_0.2.1633_darwin_amd64.tar.gz"
      sha256 "d9823522458e7b4c2a010cf534c8eb97750e42b951629ee7d46c5b8deb9ec8a5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1633/agentshield_0.2.1633_darwin_arm64.tar.gz"
      sha256 "6ab01cd1b21e53dd2eade64817e9b45861c637b96ae89f12b5cd454804adf056"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1633/agentshield_0.2.1633_linux_amd64.tar.gz"
      sha256 "74a175d612aae125975e4dcdcc21aa884e826fb22091ae0d09c8815cbcf77ce6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1633/agentshield_0.2.1633_linux_arm64.tar.gz"
      sha256 "8408c34aba88353cbff3e5869d01f6cd6089fd3d3f1a1548432c9879147b82fb"
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
