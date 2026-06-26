cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1454"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1454/agentshield_0.2.1454_darwin_amd64.tar.gz"
      sha256 "dd7441aea2badd3b1883a092ef642c0ba178821fda00043b299bf39027168d5b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1454/agentshield_0.2.1454_darwin_arm64.tar.gz"
      sha256 "0398fe792bb14cdc9675e71d7caed35ef8926dcca8a03187273b895aa8ca2bec"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1454/agentshield_0.2.1454_linux_amd64.tar.gz"
      sha256 "86abd950de6462dbf25e92d6ddf89a55dc0bb942221631b954b0d6b7fef3d7b4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1454/agentshield_0.2.1454_linux_arm64.tar.gz"
      sha256 "9e2a4190148911b83d22c39c69a45d06bb4764b38cae0dea833a4786f5a96c6f"
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
