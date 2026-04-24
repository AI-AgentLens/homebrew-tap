cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.713"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.713/agentshield_0.2.713_darwin_amd64.tar.gz"
      sha256 "62a3a6d1d931390dcb34a73fdc0de75bb93619f2693573a609d56b06b909502f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.713/agentshield_0.2.713_darwin_arm64.tar.gz"
      sha256 "89697372da069cf3afded964679d032d93678410b0308f28792b59e089b757c5"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.713/agentshield_0.2.713_linux_amd64.tar.gz"
      sha256 "e5ef411d43a22a8f87bf8d49ada67a72949ef74a7c03c9cc6f4a74befef7b753"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.713/agentshield_0.2.713_linux_arm64.tar.gz"
      sha256 "1a661f72eab3c617d316f0f2a2a4eacdaa7d12f9659d738daeb79e5cd983f456"
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
