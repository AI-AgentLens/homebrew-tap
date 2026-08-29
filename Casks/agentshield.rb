cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1981"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1981/agentshield_0.2.1981_darwin_amd64.tar.gz"
      sha256 "47748adff1279b65dce5fcc62c6be68da94103350110d8185c0f23f312abcc7e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1981/agentshield_0.2.1981_darwin_arm64.tar.gz"
      sha256 "70580df41850dede82c082026fd375e53efe90cd11633b9ff1d066e91824691f"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1981/agentshield_0.2.1981_linux_amd64.tar.gz"
      sha256 "f8f9fda0e5a519cd1e3ab8a68948afdb70fa5811aecbf18ba3ba3cbda98c349b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1981/agentshield_0.2.1981_linux_arm64.tar.gz"
      sha256 "a9fe18461f117b955726d1c30f539731a69f232b9fe13e255b302d0c7ae8c9ec"
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
