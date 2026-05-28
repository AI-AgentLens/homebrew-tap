cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1132"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1132/agentshield_0.2.1132_darwin_amd64.tar.gz"
      sha256 "1022d1484ab43811fa48e194173e6e2f884509dfe4e8697c0132bda4c2fc9ebf"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1132/agentshield_0.2.1132_darwin_arm64.tar.gz"
      sha256 "ac5fc0701a263d0654253cc9b661e3635c9b01b9e1dfb8f7fc4522ef0f1f6fd5"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1132/agentshield_0.2.1132_linux_amd64.tar.gz"
      sha256 "9dabda497cf3782f678453d354fa011319f7215077f66c4a0677f108bd65e709"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1132/agentshield_0.2.1132_linux_arm64.tar.gz"
      sha256 "05520e513839077ffed1322fa612307ad241dafd2498c5925f282a901534e84f"
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
