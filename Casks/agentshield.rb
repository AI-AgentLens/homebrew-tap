cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.729"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.729/agentshield_0.2.729_darwin_amd64.tar.gz"
      sha256 "195b11f89b46e4849efeb65c11008e35b948121d78541474b22ce6f193a3e338"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.729/agentshield_0.2.729_darwin_arm64.tar.gz"
      sha256 "1beae6d2e296ed475489092fcb3102f2a91a637f3b70eb1fff43be43e418a777"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.729/agentshield_0.2.729_linux_amd64.tar.gz"
      sha256 "e8c663017f0397cfafcf055b4ddc96744d5d87c42849661a81ef3410b4796516"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.729/agentshield_0.2.729_linux_arm64.tar.gz"
      sha256 "348171e971d056e2e78ddce05becb7214183134cffa00f4dcd583c1a57caed5b"
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
