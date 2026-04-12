cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.550"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.550/agentshield_0.2.550_darwin_amd64.tar.gz"
      sha256 "584628bbc510fa7a0c2cf1f33ef42363ad41f7bd3322cc5c80890223afd52d6f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.550/agentshield_0.2.550_darwin_arm64.tar.gz"
      sha256 "627c38ed1a0dbf4603f2bd6425b0decfccbc2054547fc1b95a0a2ca8d16d9536"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.550/agentshield_0.2.550_linux_amd64.tar.gz"
      sha256 "29581fc2c16a32264fc9787006603878e4e746f929e16a6a31442eed57c0df26"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.550/agentshield_0.2.550_linux_arm64.tar.gz"
      sha256 "1934648319627cd71839df921109e942328a534281891a4de7f2abf2341dc996"
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
