cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.244"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.244/agentshield_0.2.244_darwin_amd64.tar.gz"
      sha256 "4e276959fdcb4897fa2460621dfa3d007def116f2519622b043f1c68cb95b626"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.244/agentshield_0.2.244_darwin_arm64.tar.gz"
      sha256 "8c96c1bd83a054e43b0d21f0f3c1b13967da420b219ddf558525bfba1c04da88"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.244/agentshield_0.2.244_linux_amd64.tar.gz"
      sha256 "8e50a4efe523f31d3aa0a539854412ca23cd591c23c9dcc75e22a97df4607135"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.244/agentshield_0.2.244_linux_arm64.tar.gz"
      sha256 "ae3634d413dc5f022fc26ce3b215fd6ebe5ca92b5f4330661aa20b06e6c4ba63"
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
