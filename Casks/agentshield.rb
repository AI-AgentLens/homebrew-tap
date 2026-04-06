cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.429"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.429/agentshield_0.2.429_darwin_amd64.tar.gz"
      sha256 "2881694d005b275983ca935d17bef969035cbc64a5a6f0b56749b28b93f95efd"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.429/agentshield_0.2.429_darwin_arm64.tar.gz"
      sha256 "6bc2cebeec2ce1ae49dc5b6b21fe8ce8496c742d0a9ebcc4855148527a47fd1b"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.429/agentshield_0.2.429_linux_amd64.tar.gz"
      sha256 "f20c5f7be8cf85fb8038dd5c329694e4ecea43ccebdb656522bd6894a4b9c17e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.429/agentshield_0.2.429_linux_arm64.tar.gz"
      sha256 "cef8e7826ceec2423409b8de1bb0974ea54bbfcc368048d422fad2e433b65560"
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
