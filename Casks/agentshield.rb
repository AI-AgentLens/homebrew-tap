cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1443"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1443/agentshield_0.2.1443_darwin_amd64.tar.gz"
      sha256 "892b1885055ff50b385c15d6d6072b314c36f1295463c41f7f4821f8141c065d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1443/agentshield_0.2.1443_darwin_arm64.tar.gz"
      sha256 "67cb8f6918096b9fd4941ee31905a2b98fc26c4ba58736cf005c90b41dc42666"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1443/agentshield_0.2.1443_linux_amd64.tar.gz"
      sha256 "d5b1495c29cab2937876cb1ec6987cf6521871c284dc96f39b08cad235c0c848"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1443/agentshield_0.2.1443_linux_arm64.tar.gz"
      sha256 "b4087373e39c8b65248595b863789823d45c8c907fbfe5f7731381605486919e"
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
