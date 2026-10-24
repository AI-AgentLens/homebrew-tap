cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2519"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2519/agentshield_0.2.2519_darwin_amd64.tar.gz"
      sha256 "6e2d53344980a5e31e437bb479dc4231dee3fa4a25e0ad2e62e1ab356ef26390"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2519/agentshield_0.2.2519_darwin_arm64.tar.gz"
      sha256 "e26ff3cbff1f5181269799e6e1a7e09b7d39f1b07c4bdf6932fe06dedf7a5574"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2519/agentshield_0.2.2519_linux_amd64.tar.gz"
      sha256 "31be0b4fae3ac530991e94c7019ae5c08b0c84d3314b3fb6bb5839d8018aca6a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2519/agentshield_0.2.2519_linux_arm64.tar.gz"
      sha256 "5da185588f26bbd244b19a782e0f7fb53b16b827a919321fd2ffa3426a483211"
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
