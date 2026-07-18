cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1665"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1665/agentshield_0.2.1665_darwin_amd64.tar.gz"
      sha256 "f3d7f064949ee16b5d546053916cac7fe331326c549499d024328ac63931f7d3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1665/agentshield_0.2.1665_darwin_arm64.tar.gz"
      sha256 "b47c1c5d0bb2f0756472e220c73652df4663154368490381f11c48a041c88138"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1665/agentshield_0.2.1665_linux_amd64.tar.gz"
      sha256 "b5acfb52c6bcb34333c9b7e99c9e0b755c3ec3d05aa03fed5bfd4c85cd6198b1"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1665/agentshield_0.2.1665_linux_arm64.tar.gz"
      sha256 "2769c3ecc491483a32d1b9feb3ba836f823c2b51e2ce3fdacc21cf9916aec527"
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
