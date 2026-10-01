cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2304"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2304/agentshield_0.2.2304_darwin_amd64.tar.gz"
      sha256 "deccb322a7e54ed5e54fc94e75ca9b8f19995dc1a39e3d51a00097eb32572715"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2304/agentshield_0.2.2304_darwin_arm64.tar.gz"
      sha256 "a693bd919b9921a1fc12fdcf91e967f829f893e0479c1923d883d2bb2da1860a"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2304/agentshield_0.2.2304_linux_amd64.tar.gz"
      sha256 "9d299e6683e263132f56d1fd1507c277b14cd4bb1370679dd867c2f4bff6fd0d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2304/agentshield_0.2.2304_linux_arm64.tar.gz"
      sha256 "ca3f372d2288fd28135ba7766566806f918f3770a530b89acbf88288e1438e95"
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
