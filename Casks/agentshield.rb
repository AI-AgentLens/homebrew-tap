cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2369"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2369/agentshield_0.2.2369_darwin_amd64.tar.gz"
      sha256 "02c1f46ce60482e70c8605d3da5b72b4d67b6babaffeda9cc4771550fb4fc07a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2369/agentshield_0.2.2369_darwin_arm64.tar.gz"
      sha256 "013e8f6a29962122110e56378a68b6cbfa94525e1f7781edbe24483b8043f632"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2369/agentshield_0.2.2369_linux_amd64.tar.gz"
      sha256 "c546a2ad5fd2455ed41be6af766018b4127bfe2e938b4067506c1e1a6395d9c4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2369/agentshield_0.2.2369_linux_arm64.tar.gz"
      sha256 "0a25da49db618e17399d2d8ff6f329a090e926469ee7b60d3d6acb16b992c262"
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
