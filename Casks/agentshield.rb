cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.938"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.938/agentshield_0.2.938_darwin_amd64.tar.gz"
      sha256 "ab3b8381a7ce6c91deb3380803de0e7c0feaaeb07b1673f69800342ccfee3e09"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.938/agentshield_0.2.938_darwin_arm64.tar.gz"
      sha256 "ec2d9d47801f0d4d88eb34036002d85d4371202351f55d93624619aa225ea6c4"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.938/agentshield_0.2.938_linux_amd64.tar.gz"
      sha256 "18eb6d44b736442c0f902b350ae632a3135f5ff74f8b9fb07343ce198d4e5aab"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.938/agentshield_0.2.938_linux_arm64.tar.gz"
      sha256 "26fbbc7ed55c75cfcf66062f65dae4b2ad7cd71445773609128e6e8df47f71c8"
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
