cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.977"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.977/agentshield_0.2.977_darwin_amd64.tar.gz"
      sha256 "9e8d59987fb0308c5a078303af0ca0d932ff5ab72166635efe2d338bd38670b9"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.977/agentshield_0.2.977_darwin_arm64.tar.gz"
      sha256 "72ea08be2b8470fd0ca258851e50d6c6f2a98e7f5d1f5b6d9adc3671fed868c3"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.977/agentshield_0.2.977_linux_amd64.tar.gz"
      sha256 "78f65c353d78a479ef4f26539badfb592fabf67502f394a9e15c71208f9e7fc0"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.977/agentshield_0.2.977_linux_arm64.tar.gz"
      sha256 "05bcca5136e7eed40e9ce030adc0ec571419b0b396051e2693a328ad55e7f689"
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
