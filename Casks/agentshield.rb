cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2188"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2188/agentshield_0.2.2188_darwin_amd64.tar.gz"
      sha256 "30a6bcee08eeacf91e7ea65a1a702a659434befa3a2b669883819072d236a4e8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2188/agentshield_0.2.2188_darwin_arm64.tar.gz"
      sha256 "c66c7b629f46c1aadb6426f130d050daed963111ec902e6e6c18768d8dd4b991"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2188/agentshield_0.2.2188_linux_amd64.tar.gz"
      sha256 "99603c4983a1667108d2231e00112fc263c7c6fbd9ea243f14136ae5c99216b8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2188/agentshield_0.2.2188_linux_arm64.tar.gz"
      sha256 "d6fc18534c9fec3c9b6efa6d4112f7e2a186ecc7b26c7b1290ab319c8c9e5528"
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
