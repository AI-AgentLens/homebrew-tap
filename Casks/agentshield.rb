cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2376"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2376/agentshield_0.2.2376_darwin_amd64.tar.gz"
      sha256 "db22457293d1929f3d53d8a2805c1f170dc3d7d696b60d4087fac5649366297b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2376/agentshield_0.2.2376_darwin_arm64.tar.gz"
      sha256 "ac9839f2395a1d2d5359f09f92d5fb32b3f1ec2dc445409fdd06c4eaeee891d5"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2376/agentshield_0.2.2376_linux_amd64.tar.gz"
      sha256 "a8d6fc28a815db15a0c08508ce111fa64b120dd5b710fc4c1540633a0edf9154"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2376/agentshield_0.2.2376_linux_arm64.tar.gz"
      sha256 "4f1b5ef3ca7d1af769e91d215ffd49615ac6dd37a09658e1aa70919256bb8328"
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
