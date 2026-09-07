cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2077"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2077/agentshield_0.2.2077_darwin_amd64.tar.gz"
      sha256 "74d36265494c783da87b591b6637cdf8b1944f6ca557ad242831085a410ba06d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2077/agentshield_0.2.2077_darwin_arm64.tar.gz"
      sha256 "d22ff153f08b76fbef6ffefd6f241854628056b4f1228d0836410137f3f10792"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2077/agentshield_0.2.2077_linux_amd64.tar.gz"
      sha256 "066cc58ccb87c3a35db7d32d90215c973f87cc25218653d28728a5de76a2f798"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2077/agentshield_0.2.2077_linux_arm64.tar.gz"
      sha256 "83d09eed1c405ebd340e46d6a74868b3c6d24afb73e1c2d7662231a5faf67686"
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
