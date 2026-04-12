cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.561"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.561/agentshield_0.2.561_darwin_amd64.tar.gz"
      sha256 "c151a539d2b614de7154e6b277adabdcae603c1208d6bb44d1dc968a1a4dbcd9"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.561/agentshield_0.2.561_darwin_arm64.tar.gz"
      sha256 "f4b03015c03b6228fea1916ba59579f26cf1759a4e2c5e2e42e27ead424a9658"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.561/agentshield_0.2.561_linux_amd64.tar.gz"
      sha256 "99d2e0222149ceb0586347de95d048752e4a5d27e825431651bdc211f6ddbf41"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.561/agentshield_0.2.561_linux_arm64.tar.gz"
      sha256 "bfe159c18769206b31f582f04cae50a40c37e465d05cea48c992368930ff1bcf"
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
