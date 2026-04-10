cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.519"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.519/agentshield_0.2.519_darwin_amd64.tar.gz"
      sha256 "c84c2a0d058e059681981094f16c5d423d8097bc30cc97e3919ce83ff67760a8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.519/agentshield_0.2.519_darwin_arm64.tar.gz"
      sha256 "43e69e1737085cf7962d6183e542db377600102e346edd159d406a644f5a28bc"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.519/agentshield_0.2.519_linux_amd64.tar.gz"
      sha256 "426c901824b6ea4da2f2f400c591fdbd5835e3853206ef06d395820c80b6421c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.519/agentshield_0.2.519_linux_arm64.tar.gz"
      sha256 "29c0fde3da82ed8cbddb12f1868e286ed89fd202ad5eb45d1e06e18c1839a0a9"
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
