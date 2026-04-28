cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.783"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.783/agentshield_0.2.783_darwin_amd64.tar.gz"
      sha256 "5ef26d0b99d9ca629f65fa26eb88048789e30652844073ce2126f86401a8219c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.783/agentshield_0.2.783_darwin_arm64.tar.gz"
      sha256 "1cf30c79f0a6e5105600f0efece5bb3887e269ca93cf4f482847d0daeacb1718"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.783/agentshield_0.2.783_linux_amd64.tar.gz"
      sha256 "676be757803eb9577aa75e85288c820b27c9754749180f4d7d5c6f254acec002"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.783/agentshield_0.2.783_linux_arm64.tar.gz"
      sha256 "ac579b41a1ce4d36c8fe91eaeae71b77e3b39bd1b8ecbb3f799fc2eb92af66c1"
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
